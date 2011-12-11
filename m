From: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Subject: Re: iwlagn regression in v3.1.5
Date: Sun, 11 Dec 2011 20:20:06 +0100
Message-ID: <4EE50266.4050208@udo.edu>
References: <4EE4AEF4.2080702@udo.edu> <4EE4DB55.4090804@udo.edu>  <20111211174138.79e51fe8@x220.fritz.box>  <4EE4E152.2070204@udo.edu> <1323627815.1806.19.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Udo Steinberg <udo@hypervisor.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: wwguy <wey-yi.w.guy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323627815.1806.19.camel@wwguy-ubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

some info to the AP i use:

Technaxx Router-150 Wifi-N based on ranik soc

$ iw dev wlan0 station dump
Station xx:xx..xx:xx (on wlan0)
         inactive time:  6603 ms
         rx bytes:       377786468
         rx packets:     443535
         tx bytes:       15677515
         tx packets:     155009
         tx retries:     2723757
         tx failed:      51495
         signal:         -72 dBm
         signal avg:     -71 dBm
         tx bitrate:     135.0 MBit/s MCS 6 40Mhz short GI
         authorized:     yes
         authenticated:  yes
         preamble:       long
         WMM/WME:        yes
         MFP:            no

$ iwconfig wlan0
wlan0     IEEE 802.11abgn  ESSID:"xxx"
           Mode:Managed  Frequency:2.437 GHz  Access Point: xx:xx..xx:xx
           Bit Rate=121.5 Mb/s   Tx-Power=15 dBm
           Retry  long limit:7   RTS thr:off   Fragment thr:off
           Power Management:off
           Link Quality=42/70  Signal level=-68 dBm
           Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
           Tx excessive retries:51520  Invalid misc:3567 Missed beacon:0

some dmesg output:

[  903.748514] wlan0: authenticate with xx:xx..xx:xx (try 1)
[  903.750991] wlan0: authenticated
[  903.753357] wlan0: associate with xx:xx..xx:xx (try 1)
[  903.759482] wlan0: RX AssocResp from xx:xx..xx:xx (capab=0xc31 
status=0 aid=1)
[  903.759487] wlan0: associated

$ iwlist wlan0 scan

           Cell 06 - Address: xx:xx..xx:xx
                     Channel:6
                     Frequency:2.437 GHz (Channel 6)
                     Quality=45/70  Signal level=-65 dBm
                     Encryption key:on
                     ESSID:"xxx"
                     Bit Rates:1 Mb/s; 2 Mb/s; 5.5 Mb/s; 11 Mb/s; 9 Mb/s
                               18 Mb/s; 36 Mb/s; 54 Mb/s
                     Bit Rates:6 Mb/s; 12 Mb/s; 24 Mb/s; 48 Mb/s
                     Mode:Master
                     Extra:tsf=0000005666eac197
                     Extra: Last beacon: 33ms ago
                     IE: Unknown: 000873757065726B7568
                     IE: Unknown: 010882848B961224486C
                     IE: Unknown: 030106
                     IE: Unknown: 2A0100
                     IE: Unknown: 32040C183060
                     IE: Unknown: 
2D1A7E1117FF000000010000000000000000000000000C0000000000
                     IE: Unknown: 
3D1606070500000000000000000000000000000000000000
                     IE: Unknown: 3E0100
                     IE: IEEE 802.11i/WPA2 Version 1
                         Group Cipher : CCMP
                         Pairwise Ciphers (1) : CCMP
                         Authentication Suites (1) : PSK
                     IE: Unknown: 
DD180050F2020101800003A4000027A4000042435E0062322F00
                     IE: Unknown: 0B05020012127A
                     IE: Unknown: 4A0E14000A002C01C800140005001900
                     IE: Unknown: 7F0101
                     IE: Unknown: DD07000C4307000000
                     IE: Unknown: 0706465220010D10
                     IE: Unknown: 
DD1E00904C337E1117FF000000010000000000000000000000000C0000000000
                     IE: Unknown: 
DD1A00904C3406070500000000000000000000000000000000000000

Regards,
Andrej Gelenberg

On 12/11/2011 07:23 PM, wwguy wrote:
> On Sun, 2011-12-11 at 08:58 -0800, Andrej Gelenberg wrote:
>> Hi,
>>
>> this is pretty mean regression for the stable kernel. You may the fix
>> only for cards, which need it and not for all of them.
>
> Could you elaborate more on the failure case and setup. this patch is to
> address HT40 related problem which cause the iwlwifi firmware crash.
>
> Thanks
> Wey
>>>
>
>
