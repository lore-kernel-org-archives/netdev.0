From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 10:22:08 -0500
Message-ID: <20151229152208.GA22423@oracle.com>
References: <5682665A.7090102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30543 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbbL2PWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 10:22:15 -0500
Content-Disposition: inline
In-Reply-To: <5682665A.7090102@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Do you have admin control over the ubuntu router?
If yes, you might want to check the shared_media [#] setting 
on that router for the interfaces with overlapping subnets.
(it is on by default, I would try turning it off).

AFAICT, the code does the right thing per rfc1812 when setting
IPSKB_DOREDIRECT if shared_media is turned off.

--Sowmini

[#] https://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/theconfvariables.html
