From: Juergen Gross <jgross@suse.com>
Subject: Re: [Xen-devel] [PATCH resend] xen-netback: switch to threaded irq
 for control ring
Date: Thu, 22 Sep 2016 12:16:59 +0200
Message-ID: <2f3c7f1b-6a36-8aaa-e10a-41a1d2cf37d8@suse.com>
References: <1474534964-15621-1-git-send-email-jgross@suse.com>
 <37d32749052f4ff887c5637671085389@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "netdev@vger.kernel.orga" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <37d32749052f4ff887c5637671085389@AMSPEX02CL03.citrite.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/09/16 11:09, Paul Durrant wrote:
>> -----Original Message-----
>> From: Xen-devel [mailto:xen-devel-bounces@lists.xen.org] On Behalf Of
>> Juergen Gross
>> Sent: 22 September 2016 10:03
>> To: xen-devel@lists.xenproject.org; netdev@vger.kernel.orga; linux-
>> kernel@vger.kernel.org
>> Cc: Juergen Gross <jgross@suse.com>; Wei Liu <wei.liu2@citrix.com>
>> Subject: [Xen-devel] [PATCH resend] xen-netback: switch to threaded irq for
>> control ring
>>
>> Instead of open coding it use the threaded irq mechanism in xen-netback.
>>
>> Signed-off-by: Juergen Gross <jgross@suse.com>
> 
> How have you tested this change?

Only compile-tested and loaded the module. As this feature isn't being
used in linux netfront AFAIK it is not easily testable. OTOH the code
modification is rather limited and I've used the threaded irq in the
Xen scsiback driver myself, so I'm rather confident it will work.


Juergen
