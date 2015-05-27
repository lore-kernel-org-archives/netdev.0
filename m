From: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Subject: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Tue, 26 May 2015 22:41:48 -0700
Message-ID: <CABK1yFDtkGJ4qz3jjrGpn+-_UfOA85b2=9902QB0HBx=wC3Yyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38689 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbbE0Flt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 01:41:49 -0400
Received: by igcau1 with SMTP id au1so6020649igc.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 22:41:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

The original query I had posted is here :
http://stackoverflow.com/questions/30414350/tcp-syn-ack-tsecr-not-matching-tsval-in-syn
.. The summary is that once in a while, the TSval in SYN is not what
is getting echoed in TSecr, and looks like something on amazon aws
side is very strict about that and drops those packets. Any clues on
this - whether its a known issue/fixed elsewhere etc. would be of
great help.

Rgds,
Gopa.
