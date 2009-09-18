From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Date: Fri, 18 Sep 2009 23:54:53 +0100 (BST)
Message-ID: <5006.72.11.80.242.1253314493.squirrel@72.11.80.242>
References: <4AA6A25A.5040508@embedded.ufcg.edu.br>
    <20090912183222.GA5706@gerrit.erg.abdn.ac.uk>
    <cb00fa210909141738l60d02cd5p287d990326ce6c3c@mail.gmail.com>
    <5640c8aa0909142225q73e477fcga99a48c218d10e0b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Ivo Calado" <ivocalado@embedded.ufcg.edu.br>,
	"Gerrit Renker" <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	"netdev" <netdev@vger.kernel.org>
To: "Ian McDonald" <ian.mcdonald@jandi.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33271 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753607AbZIRWzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 18:55:01 -0400
In-Reply-To: <5640c8aa0909142225q73e477fcga99a48c218d10e0b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the delay in replying.

>> One future patch will need to modify this file, but now it's really an
>> exact copy.
>>
>>
> Basically the rule with a patch set is that all the patches should
> make sense together.
>
> It may well be that it makes sense to make a copy, but if you want to
> do this then present it with the patch that then modifies it.
>
I agree with Ian's point. At the moment I can only see patch 5/5 modifying
this file (adding documentation); from my reading of RFC 4828/5622 it seems
not necessary to use 'tfrc_sp' variants of the functions computing X.

The situation will be better as soon as the patches are in their own subtree.
Currently there is a benefit in using separate files: the tfrc library does
not support a sender-based variant of TFRC, hence requires further work
and/or
a decision to support a sender-bsed variant of CCID-3/4 only in an
experimental subtree - this requires input and discussion.

