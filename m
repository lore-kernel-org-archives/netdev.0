From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v4 1/3] net: add support for phys_port_name
Date: Tue, 24 Mar 2015 16:25:12 -0600
Message-ID: <5511E448.8050809@gmail.com>
References: <1426645397-15284-1-git-send-email-dsahern@gmail.com> <20150324151318.4e50dcbb@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35147 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbbCXWZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:25:14 -0400
Received: by ieclw3 with SMTP id lw3so9286421iec.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:25:14 -0700 (PDT)
In-Reply-To: <20150324151318.4e50dcbb@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/15 4:13 PM, Stephen Hemminger wrote:
> On Tue, 17 Mar 2015 20:23:15 -0600
> David Ahern <dsahern@gmail.com> wrote:
>
>> Similar to port id allow netdevices to specify port names and export
>> the name via sysfs. Drivers can implement the netdevice operation to
>> assist udev in having sane default names for the devices using the
>> rule:
>>
>> $ cat /etc/udev/rules.d/80-net-setup-link.rules
>> SUBSYSTEM=="net", ACTION=="add", ATTR{phys_port_name}!="",
>> NAME="$attr{phys_port_name}"
>>
>> Use of phys_name versus phys_id was suggested-by Jiri Pirko.
>>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
>> Acked-by: Jiri Pirko <jiri@resnulli.us>
>> Acked-by: Scott Feldman <sfeldma@gmail.com>
>
> Should this also be settable as well?
>
>

The intention was for this to come from the device. Currently, 
phys_port_id and phys_port_name only have get methods, so no set.

David
