From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Thu, 28 May 2015 17:30:57 +0900
Message-ID: <20150528083055.GA30133@vergenet.net>
References: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
 <20150528061542.GA2302@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34487 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbbE1IbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 04:31:04 -0400
Received: by pabru16 with SMTP id ru16so18394914pab.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 01:31:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150528061542.GA2302@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 08:15:42AM +0200, Jiri Pirko wrote:
> Thu, May 28, 2015 at 05:23:17AM CEST, simon.horman@netronome.com wrote:
> >The rocker (switch) of a rocker_port may be trivially obtained from
> >the latter it seems cleaner not to pass the former to a function when
> >the latter is being passed anyway.
> 
> I don't understand reason for this patch. I like it the way it is I must
> say. + you introduce possible multiple dereference in a row in call-chain.

My main motivation is that it seems cleaner. I marked it as an RFC
as I wasn't sure if there was a particular reason that thins are how they
are. I have no objection to leaving things as they are if thats the
consensus.
