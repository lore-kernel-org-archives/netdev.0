From: William Dauchy <wdauchy@gmail.com>
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Fri, 6 Nov 2015 08:42:30 +0100
Message-ID: <CAJ75kXZERVZRMP+OVmJ8-BjrmGTjpQzd+HEgqRrj8P0fGStD3w@mail.gmail.com>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
 <alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg> <8737xy5is2.fsf@x220.int.ebiederm.org>
 <CAGGTERk3G=q09i0v2=Yo+2CQiwSn3qyhTq7ehw7A9ez0mqK=vQ@mail.gmail.com>
 <87mvw54tcu.fsf@x220.int.ebiederm.org> <CAGGTERkduFPmoiRJ+oUQ02kXe+dbOW=5e9W3f71=9hTjG_amVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>, NETDEV <netdev@vger.kernel.org>
To: Anand Gurram <anandarao.gurram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33863 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757213AbbKFHmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 02:42:51 -0500
Received: by lbbwb3 with SMTP id wb3so52006525lbb.1
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 23:42:49 -0800 (PST)
In-Reply-To: <CAGGTERkduFPmoiRJ+oUQ02kXe+dbOW=5e9W3f71=9hTjG_amVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 6:12 PM, Anand Gurram
<anandarao.gurram@gmail.com> wrote:
> Any additional ideas and suggestions on debugging in above scenario?

You may give a try with the recent patch:
packet: race condition in packet_bind
http://www.spinics.net/lists/netdev/msg351337.html

-- 
William
