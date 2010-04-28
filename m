From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add netdev port-profile support (take
 III, was iovnl)
Date: Wed, 28 Apr 2010 11:54:26 -0700
Message-ID: <C7FDD272.2C86D%scofeldm@cisco.com>
References: <201004281513.58879.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:41201 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460Ab0D1Syb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:54:31 -0400
In-Reply-To: <201004281513.58879.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/10 6:13 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> What I could imagine to unify this is something like
> 
>    ip port_profile set DEVICE [ { pre_associate | pre_associate_rr } ]
>                               { name PORT-PROFILE | vsi MGR:VTID:VER }
>                                     mac LLADDR
>    [ vlan VID ]
>                                     [ host_uuid HOST_UUID ]
>                                     [ client_uuid CLIENT_UUID ]
>                                     [ client_name CLIENT_NAME ]
>    ip port_profile del DEVICE [ mac LLADDR [ vlan VID ] ]
>    ip port_profile show DEVICE

Arnd, can someone test this with VDP today?  I don't have access to that
equipment so it's difficult for me to fully test the unified patch.  I can
test the previous patch with enic easily because I have access to production
systems.  I'd like to make sure someone can test this with VDP before I
respin the patch one more time.

-scott

