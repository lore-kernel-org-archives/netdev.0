From: Philip Prindeville <philipp@redfish-solutions.com>
Subject: Re: [PATCH v3] iproute2: add support for GRE ignore-df knob
Date: Thu, 20 Jul 2017 18:35:23 -0600
Message-ID: <C28C1CD8-95FD-43C6-86DA-0C89D3776668@redfish-solutions.com>
References: <20170720190610.6886-1-philipp@redfish-solutions.com>
 <20170720172628.06d358b5@xeon-e3>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Michele Lucini <mlucini@safearea.com.au>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:42914 "EHLO
        mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934727AbdGUAfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 20:35:30 -0400
In-Reply-To: <20170720172628.06d358b5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jul 20, 2017, at 6:26 PM, Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
> On Thu, 20 Jul 2017 13:06:10 -0600
> "Philip Prindeville" <philipp@redfish-solutions.com> wrote:
> 
>> From: Philip Prindeville <philipp@redfish-solutions.com>
>> 
>> In the presence of firewalls which improperly block ICMP Unreachable
>> (including Fragmentation Required) messages, Path MTU Discovery is
>> prevented from working.
>> 
>> The workaround is to handle IPv4 payloads opaquely, ignoring the DF
>> bit.
>> 
>> Kernel commit 22a59be8b7693eb2d0897a9638f5991f2f8e4ddd ("net: ipv4:
>> Add ability to have GRE ignore DF bit in IPv4 payloads") is
>> complemented by this user-space changeset which exposes control of
>> this setting.
>> 
>> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
> 
> Applied, thanks Philip


Thanks!  Sorry I didn’t realize that the first submission a year ago hadn’t been applied and it took me this long to redux and resubmit it.

Michele: hopefully this comes out in your distro-of-choice fairly soon.  Like I said, I thought this had already been rolled in.

-Philip
