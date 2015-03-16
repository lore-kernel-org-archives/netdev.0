From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v2] route: label externally offloaded routes
Date: Mon, 16 Mar 2015 06:46:29 -0700
Message-ID: <5506DEB5.2030107@cumulusnetworks.com>
References: <1426447894-41398-1-git-send-email-sfeldma@gmail.com> <20150316131805.GF12614@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, jiri@resnulli.us, tarbal@gmail.com,
	linville@tuxdriver.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33337 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754284AbbCPNqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 09:46:32 -0400
Received: by pdnc3 with SMTP id c3so58874369pdn.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 06:46:31 -0700 (PDT)
In-Reply-To: <20150316131805.GF12614@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15, 6:18 AM, Andy Gospodarek wrote:
> On Sun, Mar 15, 2015 at 12:31:34PM -0700, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> v2:
>>
>> No clear outcome on polling for choices of "external", "offload", "hw", or
>> "hardware".  Andy's concern about "external" being confusing for users is
>> valid.  So, I'm making executive decision to use "external_offload" for label,
>> as suggested by Jiri.
> This seems like quite a mouthful.  Just make it 'offload' or 'hardware'
> so the output of 'ip route show' isn't so long that it will frequently
> be longer than 80 chars.  Being longer than 80 chars is going to be
> irritating for _many_ users.
>
>
+1
