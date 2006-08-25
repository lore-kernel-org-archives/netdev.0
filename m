From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/4] VM deadlock prevention -v5
Date: Fri, 25 Aug 2006 17:39:46 +0200
Message-ID: <20060825153946.24271.42758.sendpatchset@twins>
Cc: Indan Zupancic <indan@nul.nu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422724AbWHYPod@vger.kernel.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The latest version of the VM deadlock prevention work.

The basic premises is that network sockets serving the VM need undisturbed
functionality in the face of severe memory shortage.

This patch-set provides the framework to provide this.
