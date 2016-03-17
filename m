From: Patrick Boutilier <boutilpj@ednet.ns.ca>
Subject: Re: Extreme slowness in IPIP tunnel when routing through kernel 3.18
 and later
Date: Thu, 17 Mar 2016 18:13:23 -0300
Message-ID: <56EB1DF3.5000606@ednet.ns.ca>
References: <56EAB8F3.7060802@ednet.ns.ca>
 <CAEh+42h0hdNSQDZyHDWHE0qx8bf4AzP0ooaBxPXsj=bf-L5hFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090905020102050904020005"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from staff.ednet.ns.ca ([142.227.51.33]:45478 "EHLO
	staff.ednet.ns.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030395AbcCQVNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 17:13:25 -0400
In-Reply-To: <CAEh+42h0hdNSQDZyHDWHE0qx8bf4AzP0ooaBxPXsj=bf-L5hFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090905020102050904020005
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 03/17/2016 03:27 PM, Jesse Gross wrote:
> On Thu, Mar 17, 2016 at 7:02 AM, Patrick Boutilier <boutilpj@ednet.ns.ca> wrote:
>> I have an IPIP tunnel setup between two hosts in different buildings. The
>> Linux router they route through causes extreme slowness in the tunnel when
>> running kernels from 3.18 on . tcpdump shows many cksum errors which don't
>> show up in the 3.17 and earlier kernels. Speed goes back to normal when
>> rx-checksumming and tx-checksumming are turned off using ethtool on the
>> Linux router . Would this be an effect of bulk network packet transmission
>> that was introduced in 3.18 or some other issue?
>
> I just sent out a likely fix, would you mind testing it?
> https://patchwork.ozlabs.org/patch/599213/
>

Yes, that patch fixes the problem.

Thanks.

--------------090905020102050904020005
Content-Type: text/x-vcard; charset=utf-8;
 name="boutilpj.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="boutilpj.vcf"

begin:vcard
fn:Patrick Boutilier
n:Boutilier;Patrick
org:;Nova Scotia Department of Education
adr:;;2021 Brunswick Street;Halifax;NS;B3K 2Y5;Canada
email;internet:boutilpj@ednet.ns.ca
title:WAN Communications Specialist
tel;work:902-424-6800
tel;fax:902-424-0874
version:2.1
end:vcard


--------------090905020102050904020005--
