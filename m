From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][MCAST]IPv6: Check packet size when process Multicast Address
 and Source Specific Query
Date: Mon, 31 Oct 2005 11:42:28 -0800
Message-ID: <OF1A55BA31.24DA7F68-ON882570AB.006BBA0E-882570AB.006C3CFC@us.ibm.com>
References: <4365A995.3050404@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932406AbVJaTmT@vger.kernel.org>
In-Reply-To: <4365A995.3050404@21cn.com>
To: Yan Zheng <yanzheng@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think this should be modelled after the equivalent code in IGMPv3.
See igmp_heard_query() in net/ipv4/igmp.c. For ease of maintenance,
the code should be structured exactly the same way, except for
necessary differences, of course.

I haven't seen enough context yet, but  I think you need to check
for the query header itself, too (as done in IGMPv3).

I'm reviewing your other patches as well.

                                        +-DLS
