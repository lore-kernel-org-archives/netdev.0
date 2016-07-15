From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Fri, 15 Jul 2016 08:14:15 -0400
Message-ID: <5788D397.9030904@redhat.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com> <CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com> <5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com> <20160714092408.GA27271@redhat.com> <0BA3FCBA62E2DC44AF3030971E174FB3466901DA@hasmsx107.ger.corp.intel.com> <20160715112552.GB6939@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Coelho, Luciano" <luciano.coelho@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160715112552.GB6939@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/15/2016 07:25 AM, Stanislaw Gruszka wrote:
> On Thu, Jul 14, 2016 at 09:44:22AM +0000, Grumbach, Emmanuel wrote:
>>> If I understad correctly this error happen 100% of the time, not only during
>>> init. Hence seems there is an issue here, i.e. cur_ucode is not marked
>>> correctly as IWL_UCODE_REGULAR or iwl_mvm_get_temp() fail 100% of the
>>> time (iwl_mvm_is_tt_in_fw() incorrecly return true on Prarit device ? ).
>>
>> Cur_ucode will not be IWL_UCODE_REGULAR until you load the firmware which
>> will happen upon ifup.
> 
> Then creating thermal_device on ifup looks more reasonable to me.
> Otherwise we can create device that can be non-functional virtually
> forever, i.e. when soft RFKILL is enabled. However I admit that
> creating thermal_device when HW is detected has some advantages
> too.

That's my plan right now.  Unfortunately something else in the kernel seems
recently broken and is preventing me from testing.  I will get back to this
early next week.

P.
> 
> Stanislaw
> 
