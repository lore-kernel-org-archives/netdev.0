From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [Intel-wired-lan] NULL dereference on v4.1.x while enabling VF
Date: Mon, 9 May 2016 18:08:01 +0200
Message-ID: <CAJ75kXYH+Ni5tJv1Qobvx5uaibjvmTxHOiU6wDpdbD89r0Xx_Q@mail.gmail.com>
References: <CAJ75kXZV32hLzYY-dynYAj6NHm2xNoq89inmSSbqUyxPvUazEw@mail.gmail.com>
 <F6FB0E698C9B3143BDF729DF2228664691EA68EC@ORSMSX116.amr.corp.intel.com>
 <CAJ75kXY_PMK0iTyM5bbhQoAS9je5AqpW67jyZpJEUoNw0BPcqw@mail.gmail.com> <F6FB0E698C9B3143BDF729DF2228664691EA7CAF@ORSMSX116.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: NETDEV <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	Alex Duyck <aduyck@mirantis.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36496 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcEIQIW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 12:08:22 -0400
Received: by mail-lf0-f50.google.com with SMTP id u64so206073660lff.3
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 09:08:21 -0700 (PDT)
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664691EA7CAF@ORSMSX116.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hello Don,

Thank you for your help.

On Fri, May 6, 2016 at 6:26 PM, Skidmore, Donald C
<donald.c.skidmore@intel.com> wrote:
> My validation hasn't be able to recreate the dereference on v4.1.x, v4.5.x or net_next.  Where exactly did you place the two line script in your rc scripts.  Our validation was able to run it as soon as ~14 second after the first boot message logged in dmesg.  Is this anywhere close to where you were executing it?  Likewise he has attempted running at both run level 3 and 5 in case that changed any of the times of how soon the rc scripts are executed.  So the more detail you can give of setup the more it might help us recreate what you are seeing.

my script is called right at the beginning of "start" from
/etc/init.d/networking in debian jessie; so before network init.
(first trace is 40s after boot in my test)
I can't find any other details I could gave you for now but I will let
you know if I think about something else.

-- 
William
