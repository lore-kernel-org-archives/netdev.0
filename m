From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2 1/2] netem: Fix up grammatical errors in man page
Date: Mon, 23 Jan 2012 22:08:51 -0800
Message-ID: <1327385332-20776-2-git-send-email-subramanian.vijay@gmail.com>
References: <1327385332-20776-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46284 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888Ab2AXGJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 01:09:46 -0500
Received: by mail-iy0-f174.google.com with SMTP id b35so4878275iac.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 22:09:46 -0800 (PST)
In-Reply-To: <1327385332-20776-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/tc-netem.8 |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/man8/tc-netem.8 b/man/man8/tc-netem.8
index ff57624..b36d0ec 100644
--- a/man/man8/tc-netem.8
+++ b/man/man8/tc-netem.8
@@ -56,7 +56,7 @@ NetEm \- Network Emulator
 NetEm is an enhancement of the Linux traffic control facilities
 that allow to add delay, packet loss, duplication and more other
 characteristics to packets outgoing from a selected network
-interface. NetEm is build using the existing Quality Of Service (QOS)
+interface. NetEm is built using the existing Quality Of Service (QOS)
 and Differentiated Services (diffserv) facilities in the Linux
 kernel.
 
@@ -73,8 +73,8 @@ optional parameters allows to introduce a delay variation and a correlation.
 Delay and jitter values are expressed in ms while correlation is percentage.
 
 .SS distribution
-allow the choose the delay distribution. If not specified, the default
-distribution is normal. Additional parameters allow to consider situations in
+allow the user to choose the delay distribution. If not specified, the default
+distribution is Normal. Additional parameters allow to consider situations in
 which network has variable delays depending on traffic flows concurring on the
 same path, that causes several delay peaks and a tail.
 
@@ -85,7 +85,7 @@ is now deprecated due to the noticed bad behavior.
 
 .SS loss state
 adds packet losses according to the 4-state Markov using the transition
-probabilities as input parameters. The parameters p13 is mandatory and if used
+probabilities as input parameters. The parameter p13 is mandatory and if used
 alone corresponds to the Bernoulli model. The optional parameters allows to
 extend the model to 2-state (p31), 3-state (p23 and p32) and 4-state (p14).
 State 1 corresponds to good reception, State 4 to independent losses, State 3
@@ -94,7 +94,7 @@ to burst losses and State 2 to good reception within a burst.
 .SS loss gemodel
 adds packet losses according to the Gilbert-Elliot loss model or its special
 cases (Gilbert, Simple Gilbert and Bernoulli). To use the Bernoulli model, the
-only needed parameter is p while the the others will be set to the default
+only needed parameter is p while the others will be set to the default
 values r=1-p, 1-h=1 and 1-k=0. The parameters needed for the Simple Gilbert
 model are two (p and r), while three parameters (p, r, 1-h) are needed for the
 Gilbert model and four (p, r, 1-h and 1-k) are needed for the Gilbert-Elliot
@@ -103,7 +103,7 @@ the good states, 1-h is the loss probability in the bad state and 1-k is the
 loss probability in the good state.
 
 .SS corrupt
-allows the emulate the random noise introducing an error in a random position
+allows the emulation of random noise introducing an error in a random position
 for a chosen percent of packets. It is also possible to add a correlation
 through the proper parameter.
 
-- 
1.7.0.4
