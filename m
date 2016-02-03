From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next v5 1/2] ethtool: add speed/duplex validation
 functions
Date: Wed, 3 Feb 2016 15:49:04 -0800
Message-ID: <56B291F0.9010909@hpe.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-2-git-send-email-razor@blackwall.org>
 <20160204103226.333d98ca@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:54749 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933518AbcBCXtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 18:49:09 -0500
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com [15.216.225.54])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 7F35363AD2
	for <netdev@vger.kernel.org>; Wed,  3 Feb 2016 23:49:08 +0000 (UTC)
In-Reply-To: <20160204103226.333d98ca@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 03:32 PM, Stephen Hemminger wrote:

> But why check for valid value at all. At some point in the
> future, there will be yet another speed adopted by some standard body
> and the switch statement would need another value.
>
> Why not accept any value? This is a virtual device.
>

And even for not-quite-virtual devices - such as a VC/FlexNIC in an HPE 
blade server there can be just about any speed set.  I think we went 
down a path of patching some things to address that many years ago.  It 
would be a shame to undo that.

rick
