From: Christos Gkekas <chris.gekas@gmail.com>
Subject: Re: [PATCH] ath9k: debug: Simplify error checking
Date: Sat, 14 Oct 2017 09:16:07 +0100
Message-ID: <20171014081607.GB3961@inspiron>
References: <1507498152-4058-1-git-send-email-chris.gekas@gmail.com>
 <87infjw6us.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87infjw6us.fsf@purkki.adurom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/10/17 15:49:15 +0300, Kalle Valo wrote:
> Christos Gkekas <chris.gekas@gmail.com> writes:
> 
> > Variable val is unsigned so checking whether it is less than zero is
> > redundant.
> >
> > Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
> > ---
> >  drivers/net/wireless/ath/ath9k/debug.c | 5 +----
> >  1 file changed, 1 insertion(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
> > index 01fa301..3b93c23 100644
> > --- a/drivers/net/wireless/ath/ath9k/debug.c
> > +++ b/drivers/net/wireless/ath/ath9k/debug.c
> > @@ -1164,10 +1164,7 @@ static ssize_t write_file_tpc(struct file *file, const char __user *user_buf,
> >  		return -EFAULT;
> >  
> >  	buf[len] = '\0';
> > -	if (kstrtoul(buf, 0, &val))
> > -		return -EINVAL;
> > -
> > -	if (val < 0 || val > 1)
> > +	if (kstrtoul(buf, 0, &val) || val > 1)
> >  		return -EINVAL;
> 
> Same as with the ath10k patch, please keep the two if statements
> separate.
> 
> -- 
> Kalle Valo

Thanks, will submit an new, updated patch.

Christos Gkekas
