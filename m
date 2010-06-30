From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: combine duplicate code
Date: Wed, 30 Jun 2010 06:49:02 -0400
Message-ID: <1277894942.3509.25.camel@bigi>
References: <1277888098-27632-1-git-send-email-xiaosuo@gmail.com>
	 <1277893442.3509.16.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56914 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab0F3KtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 06:49:08 -0400
Received: by qyk38 with SMTP id 38so186451qyk.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 03:49:04 -0700 (PDT)
In-Reply-To: <1277893442.3509.16.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 06:24 -0400, jamal wrote:

> m->tcf_qstats.drops.

Sorry - this nagged me - we are already incrementing overlimits - we
should increment drops. Scratch that too. I am going to say your patch
as is:
signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

