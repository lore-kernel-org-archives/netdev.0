From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH/RFC net-next] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Thu, 28 May 2015 08:15:42 +0200
Message-ID: <20150528061542.GA2302@nanopsycho.orion>
References: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:36608 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbE1GPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 02:15:46 -0400
Received: by wgbgq6 with SMTP id gq6so27091951wgb.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 23:15:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 28, 2015 at 05:23:17AM CEST, simon.horman@netronome.com wrote:
>The rocker (switch) of a rocker_port may be trivially obtained from
>the latter it seems cleaner not to pass the former to a function when
>the latter is being passed anyway.

I don't understand reason for this patch. I like it the way it is I must
say. + you introduce possible multiple dereference in a row in call-chain.
