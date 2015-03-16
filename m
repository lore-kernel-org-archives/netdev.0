From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] ath10k: match wait_for_completion_timeout return type
Date: Mon, 16 Mar 2015 15:22:20 +0100
Message-ID: <20150316142220.GA30229@opentech.at>
References: <1426094076-10134-1-git-send-email-hofrat@osadl.org>
 <87y4n0q1rq.fsf@kamboji.qca.qualcomm.com> <20150313173405.GB9934@opentech.at>
 <87a8zdowyo.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
 Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <87a8zdowyo.fsf@kamboji.qca.qualcomm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Mar 2015, Kalle Valo wrote:

> Nicholas Mc Guire <der.herr@hofr.at> writes:
> 
> > On Fri, 13 Mar 2015, Kalle Valo wrote:
> >
> >> Nicholas Mc Guire <hofrat@osadl.org> writes:
> >> 
> >> > Return type of wait_for_completion_timeout is unsigned long not int.
> >> > An appropriately named unsigned long is added and the assignments fixed up.
> >> >
> >> > Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> >> 
> >> Doesn't apply:
> >> 
> >> Applying: ath10k: match wait_for_completion_timeout return type
> >> fatal: sha1 information is lacking or useless (drivers/net/wireless/ath/ath10k/mac.c).
> >> Repository lacks necessary blobs to fall back on 3-way merge.
> >> Cannot fall back to three-way merge.
> >> Patch failed at 0001 ath10k: match wait_for_completion_timeout return type
> >>
> > sorry - no idea how I managed that - checking it.
> >
> > Will fix it up and repost.
> 
> Did you use master branch from ath.git repository? ath10k is in quite
> active development so if you use something else there's a substantial
> risk that the patch will not apply.
> 
> https://wireless.wiki.kernel.org/en/users/drivers/ath10k/sources
>
no I was using linux-next - will switch to that branch for the
ath10k related cleanups (although the one I posted today was the
last from the completion fixup in ath10k - a few more in ath9k
left).

The failure of this patch was though due to a bad fix of a 
checkpatch warning - I alligned the original code rather than 
the replacement - updated my procedure so that re-applying the
patch is the final check before sending out.

thx!
hofrat
