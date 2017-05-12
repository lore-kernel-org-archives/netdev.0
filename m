From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Implementing Dynamic Rerouting in Kernel
Date: Fri, 12 May 2017 22:31:38 +0200
Message-ID: <CAHmME9qVuxFSV9fATyiYqpuk2F50j-trHQG8CAgi-8g7=sqxJQ@mail.gmail.com>
References: <CAEDnJmKWYeEwB=cBKd-cOL+hmxe0U6G7CQ8Mkwc_eP5CpJVmbA@mail.gmail.com>
 <3b6e4d7b-0e35-5944-1200-6b0721afca82@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ravish Kumar <ravishk2004@gmail.com>,
        Networking <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3b6e4d7b-0e35-5944-1200-6b0721afca82@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 11, 2017 at 6:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> What you are looking for can be done using ipset-dns from Jason:
>
> https://git.zx2c4.com/ipset-dns/about/

Funny to see this project coming up. I actually ported this
functionality into dnsmasq directly a few weeks after writing
ipset-dns, since that's a much more robust place to put this sort of
feature. It's the --ipset option.
