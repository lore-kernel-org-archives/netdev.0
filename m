From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Wed, 8 Jul 2015 05:22:21 +0000
Message-ID: <66e5e135f09943e6af144ca9f7c31c43@SIXPR30MB031.064d.mgd.msft.net>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
 <1436261876.20057.132.camel@tiscali.nl> <20150707101025.GA5003@aepfle.de>
 <cf30a808b461480d8c399e556ddef513@SIXPR30MB031.064d.mgd.msft.net>
 <20150707105836.GA19818@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150707105836.GA19818@aepfle.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Olaf Hering
> Sent: Tuesday, July 7, 2015 18:59
> Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
> 
> On Tue, Jul 07, Dexuan Cui wrote:
> 
> > OK, removing the line seems better than 'default n', though both reproduce
> > the same "# CONFIG_HYPERV_SOCK is not set".
> 
> Perhaps "default VMBUS" (or whatever syntax is needed) may be the way to
> enable it conditionally.
> 
> Olaf
Thanks, Olaf!
I think we can use "default m if HYPERV".

Paul, I'll remove the sentence "If unsure, say N."

 Thanks,
-- Dexuan
