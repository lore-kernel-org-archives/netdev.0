From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sky2: convert to new VLAN model (v0.2)
Date: Sun, 09 Jan 2011 15:54:23 -0800 (PST)
Message-ID: <20110109.155423.191399001.davem@davemloft.net>
References: <AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
	<20110107201350.0be350bf@nehalam>
	<AANLkTimyfSJwgcDOQK2hpWdJ08CNCerLM=0+NBA6+VZd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54966
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753144Ab1AIXxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 18:53:51 -0500
In-Reply-To: <AANLkTimyfSJwgcDOQK2hpWdJ08CNCerLM=0+NBA6+VZd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Sun, 9 Jan 2011 11:13:31 -0500

> On Fri, Jan 7, 2011 at 11:13 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
>> This converts sky2 to new VLAN offload flags control via ethtool.
>> It also allows for transmit offload of vlan tagged frames which
>> was not possible before.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> ---
>> Changed the setting of vlan_features in this version to keep
>> non-offload settings (GRO|HIGHDMA) even if vlan offload is not
>> enabled.
> 
> Thanks Stephen.
> 
> Reviewed-by: Jesse Gross <jesse@nicira.com>

Applied, thanks everyone.
