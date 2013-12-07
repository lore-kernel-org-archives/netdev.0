From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Sat, 07 Dec 2013 23:12:31 +0300
Message-ID: <52A3812F.4070701@cogentembedded.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>	 <52A36235.1040406@cogentembedded.com> <1386440208.2195.3.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:61892 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab3LGTM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 14:12:29 -0500
Received: by mail-lb0-f179.google.com with SMTP id l4so779787lbv.38
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 11:12:27 -0800 (PST)
In-Reply-To: <1386440208.2195.3.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/07/2013 09:16 PM, Jeff Kirsher wrote:

>>> From: Anjali Singhai Jain <anjali.singhai@intel.com>

>>> RSS can steer packets based on recognition of all
>>> sorts of different headers.  Enable some more of them.

>>> Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8

>>      This line has no place in the upstream patches, and I'm seeing it
>> in
>> several patches of this series.

> This is an internal hash id, so that we can track upstream changes back
> to internal git tree changes.  I did verify that this was acceptable and
> is being used in the kernel in upstream patches before pushing this
> information.

    First time I hear about that. Its use is constantly denied in linux-usb at 
least. Maybe netdev has its own rules regarding this though...

WBR, Sergei
