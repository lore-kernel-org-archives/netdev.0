From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Sun, 11 Dec 2016 16:37:00 +0100
Message-ID: <CAHmME9qKiAb3s98=-5PRuBWyQYECq_U56jTODSyiU_A=cuwYHQ@mail.gmail.com>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
 <095cac5b-b757-6f4a-e699-8eedf9ed7221@stressinduktion.org>
 <87vauvhwdu.fsf@alice.fifthhorseman.net> <CE942916-BF45-44CC-A5F5-3838CF9C93BC@danrl.com>
 <20161211071501.GA32621@kroah.com> <CAHmME9q5ifwwishXjXYE3J=sVeR4jYY9fLUgs_FHCP594EZr6g@mail.gmail.com>
 <20161211153027.GD29761@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-mips@linux-mips.org, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        =?UTF-8?Q?Dan_L=C3=BCdtke?= <mail@danrl.com>,
        Willy Tarreau <w@1wt.eu>,
        =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Felix Fietkau <nbd@nbd.name>, Jiri Benc <jbenc@redhat.com>,
        David Miller <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161211153027.GD29761@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 11, 2016 at 4:30 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> I'm not a crypto expert, but does this not give you a helping hand in
> breaking the crypto? You know the plain text value of these bytes, and
> where they are in the encrypted text.

You also know with some probability that there's going to be an IP
header and a TCP header, each with predictable fields. Maybe you're
reasonably certain there's an HTTP header in there too. Gasp! But fear
not...

Symmetric ciphers are generally not considered secure if they fall to
what's called a "known plaintext attack". Fortunately, modern ciphers
like AES and ChaCha20 and most others that you're aware of are
generally believed to be secure against KPA.
