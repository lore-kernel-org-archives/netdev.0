From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Tue, 16 Apr 2013 20:18:05 +0000
Message-ID: <b5d9b49f46ab434eb38a24e34f0b984b@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
 <20130416.151141.1928940532005718606.davem@davemloft.net>
 <57e8f99081a94575a57cae5e93705c22@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20130416.154912.896506198616355113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20130416.154912.896506198616355113.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Tuesday, April 16, 2013 3:49 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de; jasowang@redhat.com; linux-kernel@vger.kernel.org; devel@linuxdriverproject.org
> Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
>
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 16 Apr 2013 19:34:52 +0000
>
> > The Hyper-V hosts always use 64 bit request id. The guests can have
> > 32 or 64 bit pointers which equal to the ulong type size. So we cast 
> > it to ulong type. And, assigning 32bit integer to 64 bit variable 
> > works fine.
>
> It works fine, but it's unclean.
>
> Keep the req_id type as "u64", because that's what it is, a 64-bit request ID.

I will make this update and submit a new patch, with the added comments.

Thanks,
- Haiyang
