From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 09:13:52 +1300
Message-ID: <5640c7e00702121213p1430891el76e259aacd517c4a@mail.gmail.com>
References: <20070212160317.545906075@linux-foundation.org>
	 <20070212160336.681729431@linux-foundation.org>
	 <20070212191101.GP25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Dave Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Baruch Even" <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:53165 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965288AbXBLUNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:13:54 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2401645nfa
        for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 12:13:53 -0800 (PST)
In-Reply-To: <20070212191101.GP25760@galon.ev-en.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/13/07, Baruch Even <baruch@ev-en.org> wrote:
> * Stephen Hemminger <shemminger@linux-foundation.org> [070212 18:04]:
> > The TCP Vegas implementation is buggy, and BIC is too agressive
> > so they should not be in the default list. Westwood is okay, but
> > not well tested.
>
> Since no one really agrees on the relative merits and problems of the
> different algorithms and since the users themselves dont know, dont care
> and have no clue on what should be the correct behaviour to report bugs
> (see the old bic bugs, the htcp bugs, the recent sack bugs) I would
> suggest to avoid making the whole internet a guinea pig and get back to
> reno. If someone really needs to push high BDP flows he should test it
> himself and choose what works for his kernel at the time.
>
> For myself and anyone who asks me I recommend to set the default to
> reno. For the few who really need high speed flows, they should test
> kernel and protocol combination.
>
> Baruch

I agree wholeheartedly with Baruch. If we are going to remove BIC as
default we should go back to Reno as Cubic is even less tested in
production use than BIC.

Unless of course the papers you saw at PFLDNET showed that Cubic was a
really good choice and you want to point us to those papers.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
