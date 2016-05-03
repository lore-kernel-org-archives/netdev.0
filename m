From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [Intel-wired-lan] NULL dereference on v4.1.x while enabling VF
Date: Tue, 3 May 2016 14:32:37 +0200
Message-ID: <CAJ75kXY_PMK0iTyM5bbhQoAS9je5AqpW67jyZpJEUoNw0BPcqw@mail.gmail.com>
References: <CAJ75kXZV32hLzYY-dynYAj6NHm2xNoq89inmSSbqUyxPvUazEw@mail.gmail.com>
 <F6FB0E698C9B3143BDF729DF2228664691EA68EC@ORSMSX116.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: NETDEV <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	Alex Duyck <aduyck@mirantis.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:36111 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655AbcECMc6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 08:32:58 -0400
Received: by mail-lf0-f53.google.com with SMTP id u64so19846133lff.3
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 05:32:57 -0700 (PDT)
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664691EA68EC@ORSMSX116.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Don,

Thank you for your reply.

On Mon, May 2, 2016 at 11:33 PM, Skidmore, Donald C
<donald.c.skidmore@intel.com> wrote:
> Thanks for reporting the dereference.  Could you provide a little more detail on how you created this issue?  Are you just running the two commands (ip, sriov_numvfs) in some rc script and if you put a few second sleep in front of it you don't see the failure?

Your understanding is correct; a rc script is run with ip and echo in
numvfs commands. I tried to reduce it to the minimum. If I put a sleep
20 in front of it, it does not crash. I also forgot to add I did not
had the issue in 3.14.x with the same script.

Best,
-- 
William
