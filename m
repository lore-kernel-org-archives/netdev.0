From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 07:51:57 -0700
Message-ID: <CAJieiUiwx+1J9eUvw7woviALNDyFDEJGPfgGjjbph+xBP6xV_g@mail.gmail.com>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com>
 <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com> <CA+Jmh7GOo4K8gpyhQ8kceFtpNuASp89WYi0NR8AaoXncTCAksQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        linux-pci@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CA+Jmh7GOo4K8gpyhQ8kceFtpNuASp89WYi0NR8AaoXncTCAksQ@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 7:45 AM, Steve Lin <steven.lin1@broadcom.com> wrote:
> Hi Roopa,
>
> The attributes added in this patchset are not really the same type as
> ethtool - these are more device configuration type attributes.  The
> speeds you saw, for example, affect the pre-OS [i.e. PXE boot time]
> configuration for a port, and aren't run-time speed changes on a given
> netdev like ethtool configures.  As Jiri mentioned, I will add some
> comments to better describe each of the attributes.
>
> So I don't think there's much duplication here with ethtool.
>
> That said, there also shouldn't be anything in the patchset that would
> preclude some future migration of ethtool settings to using devlink or
> rtnetlink API.
>

ok, ack, thanks for the clarification. Just trying to find a best
netlink place for future ethtool migration to netlink.
