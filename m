From: Bhumika Goyal <bhumirks@gmail.com>
Subject: Re: [PATCH 4/6] qlogic: make device_attribute const
Date: Mon, 21 Aug 2017 22:56:56 +0530
Message-ID: <CAOH+1jEieKFo0=+xb-8FUJgaQpa_FNyvipCuokeFQmYANby2iw@mail.gmail.com>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
 <1503315792-14837-5-git-send-email-bhumirks@gmail.com> <20170821.102506.1119648270525550825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Julia Lawall <julia.lawall@lip6.fr>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Len Brown <lenb@kernel.org>, jbacik@fb.com,
        Jiri Kosina <jikos@kernel.org>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br,
        Darren Hart <dvhart@infradead.org>,
        Andy Shevchenko <andy@infradead.org>,
        Sebastian Reichel <sre@kernel.org>,
        ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net,
        linux-input@vger.kernel.org, netdev@vger.kernel.org,
        Platform Driver <platform-driver-x86@vger.kernel.org>,
        Linux PM <linux-pm@vg
To: David Miller <davem@davemloft.net>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <20170821.102506.1119648270525550825.davem@davemloft.net>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 10:55 PM, David Miller <davem@davemloft.net> wrote:
> From: Bhumika Goyal <bhumirks@gmail.com>
> Date: Mon, 21 Aug 2017 17:13:10 +0530
>
>> Make these const as they are only passed as an argument to the
>> function device_create_file and device_remove_file and the corresponding
>> arguments are of type const.
>> Done using Coccinelle
>>
>> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
>
> Applied.
>
> But I would seriously suggest that when you have to cross subsystems
> like this, just send the patches individually to the respective
> maintainers rather than trying to make a "series" out of it.
>

Yes, noted. Thanks for the pointer.

Thanks,
Bhumika

> Thanks.
