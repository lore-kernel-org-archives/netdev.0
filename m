From: "Robert Liang" <liangrob@gmail.com>
Subject: example of tcp dsack undo
Date: Tue, 20 Mar 2007 10:56:46 -0500
Message-ID: <3d2301590703200856o32f21bf1g4617c5f8033ca561@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:12723 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868AbXCTP4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 11:56:48 -0400
Received: by nf-out-0910.google.com with SMTP id o25so424678nfa
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 08:56:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

While designing some testing examples for the undo mechanisms, I found that
undo_dsack is only used when the state is Disorder. However, I assume that
dsack happens when there are retransmissions, which means Recovery or Loss.

I can think of an example of receiving dsack following a successful
recovery. But
the dsack ACKs old data and can not bring the state into Disorder.
Can anybody give me an example when *valid* dsack is received while in Disorder
state.


Thank you!

rl
