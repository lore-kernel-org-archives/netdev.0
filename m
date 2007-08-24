From: Shirley Ma <xma@us.ibm.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 10:45:17 -0700
Message-ID: <OFB48299BB.9D9BCE91-ON87257341.006139E9-88257341.00614EB7@us.ibm.com>
References: <20070824165110.GH4282@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: akepner@sgi.com, linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Marcus@ozlabs.org,
	Eder <meder@de.ibm.com>, netdev <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759476AbXHXRpi@vger.kernel.org>
In-Reply-To: <20070824165110.GH4282@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Just to be clear, in the previous email I posted on this thread, I
> described a worst-case network ping-pong test case (send a packet, wait
> for reply), and found out that a deffered interrupt scheme just damaged
> the performance of the test case. 

When splitting rx and tx handler, I found some performance gain by 
deffering interrupt scheme in tx not rx in IPoIB driver.

Shirley
