From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 1/3] net: add support for phys_port_name
Date: Wed, 25 Mar 2015 07:37:51 +0100
Message-ID: <20150325063751.GA2034@nanopsycho.orion>
References: <1426645397-15284-1-git-send-email-dsahern@gmail.com>
 <20150324151318.4e50dcbb@urahara>
 <5511E448.8050809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, sfeldma@gmail.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38334 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbCYGhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 02:37:55 -0400
Received: by wibgn9 with SMTP id gn9so23848293wib.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 23:37:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5511E448.8050809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 24, 2015 at 11:25:12PM CET, dsahern@gmail.com wrote:
>On 3/24/15 4:13 PM, Stephen Hemminger wrote:
>>On Tue, 17 Mar 2015 20:23:15 -0600
>>David Ahern <dsahern@gmail.com> wrote:
>>
>>>Similar to port id allow netdevices to specify port names and export
>>>the name via sysfs. Drivers can implement the netdevice operation to
>>>assist udev in having sane default names for the devices using the
>>>rule:
>>>
>>>$ cat /etc/udev/rules.d/80-net-setup-link.rules
>>>SUBSYSTEM=="net", ACTION=="add", ATTR{phys_port_name}!="",
>>>NAME="$attr{phys_port_name}"
>>>
>>>Use of phys_name versus phys_id was suggested-by Jiri Pirko.
>>>
>>>Signed-off-by: David Ahern <dsahern@gmail.com>
>>>Acked-by: Jiri Pirko <jiri@resnulli.us>
>>>Acked-by: Scott Feldman <sfeldma@gmail.com>
>>
>>Should this also be settable as well?
>>
>>
>
>The intention was for this to come from the device. Currently, phys_port_id
>and phys_port_name only have get methods, so no set.

Makes no sense to have set for these two.

>
>David
