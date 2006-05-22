From: "Ian McDonald" <imcdnzl@gmail.com>
Subject: Re: How to submit a new module to linux kernel?
Date: Tue, 23 May 2006 09:41:09 +1200
Message-ID: <cbec11ac0605221441t7d037789ma2fcf45e2617996f@mail.gmail.com>
References: <A975FFC51622704CBEAB749E263D1799015540AA@mail01.student.main.ntu.edu.sg>
	 <20060522160650.GG28093@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.204]:46529 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751207AbWEVVlK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 17:41:10 -0400
Received: by nz-out-0102.google.com with SMTP id 8so1399291nzo
        for <netdev@vger.kernel.org>; Mon, 22 May 2006 14:41:10 -0700 (PDT)
To: "Erik Mouw" <erik@harddisk-recovery.com>
In-Reply-To: <20060522160650.GG28093@harddisk-recovery.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/23/06, Erik Mouw <erik@harddisk-recovery.com> wrote:
> On Mon, May 22, 2006 at 03:18:12PM +0800, #ZHOU BIN# wrote:
> > I'm new in this mailing list. I implemented a new TCP congestion
> > control module for linux kernel 2.6.16.13.
> > Does anybody know how to apply for the integration of it into the
> > linux kernel? How long will this process take?
>
> See Documentation/SubmittingPatches in your kernel tree.
>
>
I would also add that for this type of patch a peer reviewed paper
outlining the congestion control work would be useful/needed.

Every person wants to improve TCP and has written a congestion control
mechanism (myself included!) but that doesn't mean it is worth
including in the kernel (mine certainly isn't....).

In particular for TCP congestion control you need to show in what
cases it is better than others, what cases it is worse and how fair is
it compared to other TCP flows.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
