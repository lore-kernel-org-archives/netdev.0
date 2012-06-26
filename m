From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: New commands to configure IOV features
Date: Tue, 26 Jun 2012 15:21:55 +0300
Message-ID: <4FE9A963.7020602@broadcom.com>
References: <4FA7AF62.8000405@broadcom.com>
 <20120507081634.000003f8.gregory.v.rose@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Greg Rose" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4183 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754432Ab2FZMXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 08:23:44 -0400
In-Reply-To: <20120507081634.000003f8.gregory.v.rose@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2012 06:16 PM, Greg Rose wrote:

> On Mon, 7 May 2012 14:17:54 +0300
> Yuval Mintz <yuvalmin@broadcom.com> wrote:
> 
>> I've tried to figure out if there was a standard interface
>> (ethtool/iproute) through which a user could configure the number
>> of vfs in his system.
>>
>> I've seen the RFC suggested in
>> http://markmail.org/thread/qblfcv7zbxsxp7q6, and
>> http://markmail.org/thread/fw54dcppmxuxoe6n, but failed to see any
>> later references to it (commits or further discussion on this topic).
>>
>> How exactly are things standing with these RFCs? Were they abandoned?
> 
> The only way to configure the number of VFs continues to be through the
> max_vfs module parameter.  I've got a patch to do it through ethtool
> sitting on the back burner but due to other requirements of my day job
> I've not been able to work on it since last fall.
> 
> - Greg


Hi Ben,

If I want to pick the RFCs and add support for configuring the number of
VFs - do you think ethtool's the right place for such added support?

I'm asking since as far as I can see, ethtool (today) doesn't contain any
features related to virtual functions.

Thanks,
Yuval
