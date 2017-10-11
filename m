From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] xdp: Sample xdp program implementing ip forward
Date: Wed, 11 Oct 2017 10:08:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0090EEE@AcuExch.aculab.com>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
        <1507620532-25804-2-git-send-email-Christina.Jacob@cavium.com>
 <20171010210607.2af452e2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "Sunil.Goutham@cavium.com" <Sunil.Goutham@cavium.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "dsahern@gmail.com" <dsahern@gmail.com>,
        Christina Jacob <Christina.Jacob@cavium.com>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
        Christina Jacob <christina.jacob.koikara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010210607.2af452e2@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer
> Sent: 10 October 2017 20:06
...
> > +		int src_ip = 0, dest_ip = 0;
...
> > +			key4.b8[4] = dest_ip % 0x100;
> > +			key4.b8[5] = (dest_ip >> 8) % 0x100;
> > +			key4.b8[6] = (dest_ip >> 16) % 0x100;
> > +			key4.b8[7] = (dest_ip >> 24) % 0x100;

Do you really want signed remainders done here?

	David
