From: Jan Engelhardt <jengelh@medozas.de>
Subject: ip_local_out missing skb->protocol assignment
Date: Wed, 8 Jul 2009 23:37:47 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0907082335190.12710@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


I noticed that skb->protocol is not set for Netfilter hooks with 
NF_INET_LOCAL_OUT. Reason for that is that skb->protocol is only set 
within ip_output, i.e. shortly before NF_INET_POST_ROUTING. Was there a 
specific reason setting ->protocol is delayed for locally-output 
traffic?

Jan
