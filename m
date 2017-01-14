From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] cxgb4:  Remove redundant memset before memcpy
Date: Sat, 14 Jan 2017 13:27:40 +0100
Message-ID: <20170114122739.GG1201@distanz.ch>
References: <1484356660-19082-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Shyam Saini <mayhs11saini@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1484356660-19082-1-git-send-email-mayhs11saini@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-01-14 at 02:17:40 +0100, Shyam Saini <mayhs11saini@gmail.com> wrote:
> The region set by the call to memset, immediately overwritten by
> the subsequent call to memcpy and thus makes the  memset redundant.
> 
> Also remove the memset((&info, 0, sizeof(info)) on line 398 because
> info is memcpy()'ed to before being used in the loop and it isn't
> used outside of the loop.
> 
> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
