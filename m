From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/6] ip/ipnetns: prevent potential string buffer
 overflow
Date: Wed, 12 Aug 2015 08:48:44 -0700
Message-ID: <20150812084844.06510981@urahara>
References: <1438863876-1935-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33716 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbbHLPsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 11:48:41 -0400
Received: by pabyb7 with SMTP id yb7so17045228pab.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 08:48:40 -0700 (PDT)
In-Reply-To: <1438863876-1935-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than chopping the string off, I decided to solve the problem by changing
network namespace cache to use variable length structure.
