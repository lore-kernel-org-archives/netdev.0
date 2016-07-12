From: Andreas Noever <andreas.noever@gmail.com>
Subject: Re: [PATCH v2 0/8] thunderbolt: Introducing Thunderbolt(TM) networking
Date: Wed, 13 Jul 2016 00:19:40 +0200
Message-ID: <CAMxnaaWB2SR-d=JV3njmrbeCjE30DNFQ5YLXy748hjYZPayXWw@mail.gmail.com>
References: <1467189336-29556-1-git-send-email-amir.jer.levy@intel.com> <E607265CB020454880711A6F96C05A03893CAB6E@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E607265CB020454880711A6F96C05A03893CAB6E@hasmsx107.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 12, 2016 at 12:50 PM, Levy, Amir (Jer)
<amir.jer.levy@intel.com> wrote:
> On Wed, Jun 29 2016, 11:35 AM, Levy, Amir (Jer) wrote:
>> This is version 2 of Thunderbolt(TM) driver for non-Apple hardware.
>>
>> Changes since v1:
>>  - Separation to 2 modules.
>>  - Moved ICM specific registers definition to ICM header file.
>>  - Added new Thunderbolt device IDs.
>>  - Renamed the Thunderbolt networking documentation.
>>  - General cleanups
>>
>> These patches were pushed to GitHub where they can be reviewed more
>> comfortably with green/red highlighting:
>>       https://github.com/01org/thunderbolt-software-kernel-tree
>>
>> Daemon code:
>>       https://github.com/01org/thunderbolt-software-daemon
>>
>> For reference, here's a link to version 1:
>> [v1]: http://www.spinics.net/lists/linux-pci/msg51287.html
>>
>> Amir Levy (8):
>>   thunderbolt: Macro rename
>>   thunderbolt: Updating device IDs
>>   thunderbolt: Updating the register definitions
>>   thunderbolt: Kconfig for Thunderbolt(TM) networking
>>   thunderbolt: Communication with the ICM (firmware)
>>   thunderbolt: Networking state machine
>>   thunderbolt: Networking transmit and receive
>>   thunderbolt: Networking doc
>>
>>  Documentation/00-INDEX                   |    2 +
>>  Documentation/thunderbolt-networking.txt |  135 ++
>>  drivers/thunderbolt/Kconfig              |   25 +-
>>  drivers/thunderbolt/Makefile             |    4 +-
>>  drivers/thunderbolt/icm_nhi.c            | 1631 +++++++++++++++++++++
>>  drivers/thunderbolt/icm_nhi.h            |   84 ++
>>  drivers/thunderbolt/net.c                | 2277
>> ++++++++++++++++++++++++++++++
>>  drivers/thunderbolt/net.h                |  274 ++++
>>  drivers/thunderbolt/nhi_regs.h           |  115 +-
>>  include/linux/pci_ids.h                  |   44 +-
>>  10 files changed, 4565 insertions(+), 26 deletions(-)  create mode 100644
>> Documentation/thunderbolt-networking.txt
>>  create mode 100644 drivers/thunderbolt/icm_nhi.c  create mode 100644
>> drivers/thunderbolt/icm_nhi.h  create mode 100644
>> drivers/thunderbolt/net.c  create mode 100644 drivers/thunderbolt/net.h
>>
>> --
>> 2.7.4
>
> Hi All,
> Do you have any comments or suggestions for this patch set?

Since this is now a separate driver I would prefer if it was in a
different (sub)directory (maybe thunderbolt/icm?).

> Regards,
> Amir
