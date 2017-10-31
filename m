From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Problems with mvneta
Date: Tue, 31 Oct 2017 21:23:04 +0100
Message-ID: <20171031212304.38a3d723@windsurf>
References: <20171018223425.42ce7a74@gmx.de>
        <20171018225557.43837338@windsurf.home>
        <20171020002524.4b4cf122@gmx.de>
        <20171020090956.2b6cc34b@windsurf.home>
        <01d0cd47-20ef-bbad-cd93-749cc94d0d2f@cloudguard.ch>
        <20171023113024.7138970e@r84n0nz>
        <20171031152322.3e180c30@gmx.de>
        <20171031152740.72ab6829@windsurf>
        <20171031170938.GC18407@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Sven =?UTF-8?B?TcO8bGxlcg==?= <musv@gmx.de>,
        Andreas Tobler <andreas.tobler@cloudguard.ch>,
        =?UTF-8?B?R3LDqWdvcnk=?= Clement
        <gregory.clement@free-electrons.com>,
        Antoine =?UTF-8?B?VMOpbmFydA==?=
        <antoine.tenart@free-electrons.com>, netdev@vger.kernel.org,
        Marcin Wojtas <mw@semihalf.com>
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:37769 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932356AbdJaUXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 16:23:38 -0400
In-Reply-To: <20171031170938.GC18407@kw.sim.vm.gnt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, 31 Oct 2017 18:09:38 +0100, Simon Guinot wrote:

> > On Tue, 31 Oct 2017 15:23:22 +0100, Sven Müller wrote:  
> > > After quite a long time of trying to reproduce the issue without any success I got 3 network crashes today. And all errors occurred with a kernel including the patch: 
> > > 
> > > 2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a
> > > 
> > > At least according to Andreas' and my problems we can exclude the 6ad2 patch as the source of the errors.   
> > 
> > Simon, 2a90f7e1d5d04e4f1060268e0b55a2c702bbd67a is your commit, adding
> > xmit_more support, and a number of people are reporting stability
> > issues with this patch applied.  
> 
> I wrote an earlier version of this patch. But I think this commit has
> been modified by the submitter Marcin Wojtas because I don't remember
> anything about the maximum number of descriptors allowed to be flush.
> 
> > 
> > Do you think you will have some time to look into this ?  
> 
> No I don't have time to look into that.
> 
> But after a quick look, I wonder what is happening if
> "txq->pending + frags > MVNETA_TXQ_DEC_SENT_MASK" ? Because IIUC
> mvneta_txq_pend_desc_add() is called anyway. And according to the
> comment inside the function, it assumes there is less than 255
> descriptors to send... It looks suspect.

Thanks for the feedback. Marcin, do you remember this xmit_more patch?

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
