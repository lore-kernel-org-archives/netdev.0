From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next V2 4/6] igb: call	ndo_stop()
	instead of dev_close() when running offline selftest
Date: Tue, 16 Feb 2016 17:24:34 +0000
Message-ID: <CBCD8DCD-53A4-4628-A760-592A6CE15A73@intel.com>
References: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>
 <1454487652-1545-5-git-send-email-sassmann@kpanic.de>
 <309B89C4C689E141A5FF6A0C5FB2118B81E89BFE@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_6683920E-98E3-4B2C-B15E-7323027A36D1";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8771 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755459AbcBPRYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 12:24:36 -0500
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B81E89BFE@ORSMSX101.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_6683920E-98E3-4B2C-B15E-7323027A36D1
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Aaron F <aaron.f.brown@intel.com> wrote:

>> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on  
>> behalf of Stefan Assmann [sassmann@kpanic.de]
>> Sent: Wednesday, February 03, 2016 12:20 AM
>> To: intel-wired-lan@lists.osuosl.org
>> Cc: netdev@vger.kernel.org; davem@davemloft.net; sassmann@kpanic.de
>> Subject: [Intel-wired-lan] [PATCH net-next V2 4/6] igb: call ndo_stop()  
>> instead of dev_close() when running offline selftest
>>
>> Calling dev_close() causes IFF_UP to be cleared which will remove the
>> interfaces routes and some addresses. That's probably not what the user
>> intended when running the offline selftest. Besides this does not happen
>> if the interface is brought down before the test, so the current
>> behaviour is inconsistent.
>> Instead call the net_device_ops ndo_stop function directly and avoid
>> touching IFF_UP at all.
>>
>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>> ---
>>  drivers/net/ethernet/intel/igb/igb.h         | 2 ++
>>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
>>  drivers/net/ethernet/intel/igb/igb_main.c    | 8 ++++----
>>  3 files changed, 8 insertions(+), 6 deletions(-)
>
> Checkpatch warns that externs should be avoided in .c files, but they  
> pre-existed and are just being flagged due to the name changing, so...
>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>

Again, the prototypes in the .c should be deleted in favor of the ones that  
were added to the .h file.
--Apple-Mail=_6683920E-98E3-4B2C-B15E-7323027A36D1--
