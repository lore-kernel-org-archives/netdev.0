From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Mon, 13 Sep 2010 19:00:51 +0200
Message-ID: <4C8E58C3.7060108@redhat.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <201009091319.40274.rusty@rustcorp.com.au> <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com> <201009092144.26484.rusty@rustcorp.com.au> <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com> <20100912114637.GB22982@redhat.com> <OF32429FD6.3F8CAEC5-ON6525779D.00169473-6525779D.0017A613@in.ibm.com> <20100913090415.GB29333@redhat.com> <4C8E4A66.8030907@codemonkey.ws> <20100913163037.GA18233@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100913163037.GA18233@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  On 09/13/2010 06:30 PM, Michael S. Tsirkin wrote:
> Trouble is, each vhost-net device is associated with 1 tun/tap
> device which means that each vhost-net device is associated with a
> transmit and receive queue.
>
> I don't know if you'll always have an equal number of transmit and
> receive queues but there's certainly  challenge in terms of
> flexibility with this model.
>
> Regards,
>
> Anthony Liguori
> Not really, TX and RX can be mapped to different devices,
> or you can only map one of these. What is the trouble?

Suppose you have one multiqueue-capable ethernet card.  How can you 
connect it to multiple rx/tx queues?

tx is in principle doable, but what about rx?

What does "only map one of these" mean?  Connect the device with one 
queue (presumably rx), and terminate the others?


Will packet classification work (does the current multiqueue proposal 
support it)?


-- 
error compiling committee.c: too many arguments to function

