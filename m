From: Kamala R <kamala@aristanetworks.com>
Subject: IPv6: Blackhole route support partial ?
Date: Mon, 11 Nov 2013 19:25:14 +0530
Message-ID: <CAP8BHkGZ5EFxW4BNervKrOiEaQTNdSh9s2YOrFoexzQCOR=AqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:34830 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab3KKNzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 08:55:15 -0500
Received: by mail-qa0-f45.google.com with SMTP id hu16so1832883qab.18
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 05:55:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On adding IPv6 blackhole routes, ICMP unreachable messages are being
sent back to source. According to the definition, packets destined to
a blackhole address must be dropped silently.


I applied the patch submitted to the 3.7 kernel that indicates that it
supports blackhole and prohibit routes correctly. However, the patch
only sets the error code and route type correctly, so the show command
displays the appropriate output.


It seems to me that the input and output function pointers of the dst
variable, which determine packet processing, need to be set to
dst_discard. This would enable correct behaviour for blackhole routes.
Am I on the right path here ?

Thanks and Regards,
Kamala
