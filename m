From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Mon, 27 Sep 2004 20:54:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927205453.79f9628f.rddunlap@osdl.org>
References: <414A3562.2090803@pobox.com>
	<005801c4a4f4$1598d6d0$a010100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, leonid.grossman@s2io.com,
        raghavendra.koushik@s2io.com, rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: <ravinandan.arakali@s2io.com>
In-Reply-To: <005801c4a4f4$1598d6d0$a010100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 17:42:51 -0700 Ravinandan Arakali wrote:

| Hi,
| Attached are the updated patches. It is designed to work on the latest
| kernel. Also, this time the submission is split to 3 patches(they need
| to applied in the order mentioned below).
| 
| s2io_styling_level1  - Contains
|                              a. styling related, function name changes.
|                              b. fix for 32-bit systems.
|                              c. modified Transmit descriptor allocation
| strategy.
|                              d. miscellaneous fixes.
| with_napi_level2     - Fixes/tunes NAPI feature
| with_2buff_level3    - Adds support for 2-buffer mode.
| 
| Please review and get back with your comments.

The focused nature of the NAPI and 2BUFF patches are good IMO.

It would be very helpful if the styling patch had all comments/whitespace/style
changes split out from it (maybe 3000 of the 4000 lines of the patch).
Then we (reviewers) could spend time focusing on the important parts of
your patches, and the styling patch could go with some lighter review.

I'd like to help Jeff with some review here, but it's become too painful &
time-consuming for me to wade thru the patches looking for the
more-important parts of such a large patch, so I'll have to leave it to
Jeff and other netdev regulars.


| Thanks,
| Ravi
| 
| -----Original Message-----
| From: Jeff Garzik [mailto:jgarzik@pobox.com]
| Sent: Thursday, September 16, 2004 5:53 PM
| To: ravinandan.arakali@s2io.com
| Cc: netdev@oss.sgi.com; leonid.grossman@s2io.com;
| raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com
| Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel
| 
| 
| Ravinandan Arakali wrote:
| > Jeff,
| > We tried it out with 2.6.7. Can you pls specify the kernel version
| > on which you tried and we will send a patch which works for that version.
| > We will also send a more detailed description of the changes along with
| > that.
| 
| 
| Always diff against the latest version of the kernel.  You can find out
| the latest version by going to http://www.kernel.org/  You'll typically
| want the latest snapshot (preferably), or the latest pre-patch.
| 
| Standard patch submission format is described at
| http://linux.yyz.us/patch-format.html and in
| Documentation/SubmittingPatches.
| 
| When submitting a series of patches, it is normal patches to depend on
| preceding patches.


--
~Randy
