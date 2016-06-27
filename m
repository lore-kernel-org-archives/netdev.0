From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 6/6] r8152: add byte_enable for ocp_read_word
 function
Date: Mon, 27 Jun 2016 13:57:22 +0300
Message-ID: <d350382e-3798-f9c9-1639-45db15fceeca@cogentembedded.com>
References: <1394712342-15778-184-Taiwan-albertk@realtek.com>
 <1394712342-15778-190-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33788 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbcF0K5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 06:57:25 -0400
Received: by mail-lf0-f53.google.com with SMTP id f6so153300872lfg.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 03:57:25 -0700 (PDT)
In-Reply-To: <1394712342-15778-190-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/27/2016 8:07 AM, Hayes Wang wrote:

> Add byte_enable for ocp_read_word() to replace reading 4 bytes data
> with reading the desired 2 bytes data.
>
> This is used to avoid the issue which is described in commit:b4d99def.

    scripts/checkpatch.pl now enforces certain commit citing style, yours 
doesn't match.

> The origin method always reads 4 bytes data, and it may have problem
> when reading the PHY regiters.

    Registers.

> The new method is supported since RTL8152B, but it doesn't influence
> the previous chips. The bits of the byte_enable for the previous chips
> are the reserved bits, and the hw would ignore them.
>
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

[...]

MBR, Sergei
