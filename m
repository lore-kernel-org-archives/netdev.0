From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: A question about Forward ACKed packets
Date: Wed, 1 Jun 2011 00:09:40 +0200
Message-ID: <BANLkTikRTzCZ9y8dZUMRGx3zd6X5jqXkNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:63477 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758244Ab1EaWJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 18:09:40 -0400
Received: by iwn34 with SMTP id 34so3976260iwn.19
        for <netdev@vger.kernel.org>; Tue, 31 May 2011 15:09:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to understand the concept of Forward Acknowledgements
(FACK). What confuses me most is the variable fackets_out, which,
according to the source code, is equal to the "FACK'd packets".

Isn't by definition only a single packet "the most Forward ACKed
packet"...? If not, what are "FACK'd packets"? Is fackets_out the
number of "gaps" between SACKed data?

Greetings,
Dominik
