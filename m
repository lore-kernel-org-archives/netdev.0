From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH] ethernet: fm10k: Actually drop 4 bits
Date: Mon, 26 Jan 2015 16:58:13 +0000
Message-ID: <D0EBB1E6.6855F%matthew.vick@intel.com>
References: <1421967198-16667-1-git-send-email-linux@rasmusvillemoes.dk>
 <D0E81E0C.682EB%matthew.vick@intel.com> <87twzhknnl.fsf@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87twzhknnl.fsf@rasmusvillemoes.dk>
Content-Language: en-US
Content-ID: <BC1833DA4954844B8EA32498F76E075F@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/15, 4:50 PM, "Rasmus Villemoes" <linux@rasmusvillemoes.dk> wrote:

>On Sat, Jan 24 2015, "Vick, Matthew" <matthew.vick@intel.com> wrote:
>
>> Good catch! I noticed this too and was getting a patch together to
>>address
>> this.
>>
>> The difference is that I was planning on not silently accepting an
>>invalid
>> VLAN ID to begin with and returning FM10K_ERR_PARAM if the VLAN was
>> invalid, which I think is a better approach for this situation. If it's
>> alright with you, I'll generate the patch shortly and credit you via
>>your
>> Reported-by.
>
>Sure, do what you think is best.
>
>Rasmus

Sounds good. I'll get the patch created and validated through Jeff's tree.

Cheers,
Matthew
