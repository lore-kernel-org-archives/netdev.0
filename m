From: Andreas Noever <andreas.noever@gmail.com>
Subject: Re: [PATCH v6 0/8] thunderbolt: Introducing Thunderbolt(TM) networking
Date: Sun, 11 Sep 2016 01:19:01 +0200
Message-ID: <CAMxnaaUato=3mkS0mfKegW-C0y-+_+OZi1NZAJmc4Dv4dDui6A@mail.gmail.com>
References: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com> <20160831112813.GB17607@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Levy <amir.jer.levy@intel.com>,
        Bjorn Helgaas <bhelgaas@google.com>, corbet@lwn.net,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        thunderbolt-linux <thunderbolt-linux@intel.com>,
        "Westerberg, Mika" <mika.westerberg@intel.com>,
        "Winkler, Tomas" <tomas.winkler@intel.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831112813.GB17607@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2016 at 1:28 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Mon, Aug 01, 2016 at 03:23:45PM +0300, Amir Levy wrote:
>> This is version 6 of Thunderbolt(TM) driver for non-Apple hardware.
>>
>> Changes since v5:
>>  - Removed the padding of short packets in receive
>>  - Replaced RW semaphore with mutex
>>  - Cleanup
>>
>> These patches were pushed to GitHub where they can be reviewed more
>> comfortably with green/red highlighting:
>>       https://github.com/01org/thunderbolt-software-kernel-tree
>>
>> Daemon code:
>>       https://github.com/01org/thunderbolt-software-daemon
>>
>> For reference, here's a link to version 5:
>> [v5]: https://lkml.org/lkml/2016/7/28/85
>
> Without acks from the thunderbolt maintainer, or any network driver
> developers, I'm not going to take this series.  Please work to get that
> review.

Sorry for the late response. I was away for the last two weeks and
will be away again for the next week.

This driver is independent from mine. It uses an interface provided by
the firmware which is not present on Apple hardware and with which I
am not familiar (also it does networking, not pci with which I am also
not familiar). So I cannot comment on the driver itself. I don't mind
a second driver, if that is what you are asking.

Andreas
