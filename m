From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: RFC: remove NET_CLS_POLICE?
Date: Sun, 26 Nov 2006 23:09:21 +0000
Message-ID: <456A1EA1.8020404@andyfurniss.entadsl.com>
References: <20061126062939.GM15364@stusta.de>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:22955 "EHLO mail.ukfsn.org")
	by vger.kernel.org with ESMTP id S1754075AbWKZXJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Nov 2006 18:09:09 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061126062939.GM15364@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Considering that NET_CLS_POLICE has been marked as obsolete for more 
> than one year, would a patch to remove it be acceptable?
> 
> cu
> Adrian
> 

People still request the "2.4 policer" on LARTC as unlike its 
replacement it hooks after prerouting/denat so they can police on local 
addresses.

There is no other way apart from IMQ, though ISTR mention of a meta 
match one day (for ifb).

Andy.

