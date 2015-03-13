From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH 2/3 RFC] ath10k: wmi: match wait_for_completion_timeout
	return type
Date: Fri, 13 Mar 2015 17:24:09 +0100
Message-ID: <20150313162409.GA5939@opentech.at>
References: <1426175362-8640-1-git-send-email-hofrat@osadl.org> <87bnjwrhse.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath10k@lists.infradead.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:54677 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932168AbbCMQYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 12:24:11 -0400
Content-Disposition: inline
In-Reply-To: <87bnjwrhse.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Mar 2015, Kalle Valo wrote:

> Nicholas Mc Guire <hofrat@osadl.org> writes:
> 
> > Return type of wait_for_completion_timeout is unsigned long not int.
> > An appropriately named unsigned long is added and the assignments fixed up.
> > Rather than returning 0 (timeout) or a more or less random remaining time
> > (completion success) this return 0 or 1 which also resolves the type of the
> > functions being int.
> >
> > Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> 
> Why does patch 2 in this patchset have RFC in the title but patches 1
> and 3 not? That just makes me confused, I can't tell what you want me to
> do with the patches. Normally I just drop all patches (or patchsets)
> which have RFC, and that's what I'm going to do now.
> 
> To save everyone's time, when submitting something please state clearly
> what's your intention.
>
ok - was simply unsure about the proposed change 
and 1 was a trivial cleanup (which should have been 
sent out as a seperate patch and not part of a series - my mistake)

Will fix this up and repost it.

sorry for the screwup - no intent to wast anybodies time.

thx!
hofrat
 
