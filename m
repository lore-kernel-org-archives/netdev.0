From: Chris Leech <cleech@redhat.com>
Subject: Re: [RFC PATCH 0/5] Reorganize libfcoe control interfaces
Date: Tue, 11 Sep 2012 10:12:09 -0700
Message-ID: <CAHNqLyXhUo9ny3Wez5kWazaj_bk7mOEqvB8TemkFsu8ZP-ypXw@mail.gmail.com>
References: <20120910225908.13140.97277.stgit@fritz>
	<504E8040.70403@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Robert Love <robert.w.love@intel.com>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, linux-scsi@vger.kernel.org,
	devel@open-fcoe.org
To: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <504E8040.70403@broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2012 at 5:05 PM, Bhanu Prakash Gollapudi
<bprakash@broadcom.com> wrote:
>
> I'm concerned that we will be breaking user space compatibility with this
> change, as there should be a corresponding fcoemon/fipvlan change along with
> this, and existing utilities will not work.  Also the way we start fcoe will
> be completely different and the user may need to do the scripting changes,
> if any.
>

I agree with Bhanu on these concerns, even though I hope everyone's
using fcoeadm/fcoemon/fipvlan.  I think there needs to be more of a
transition plan than requiring everyone moving to a new kernel to
update the user-space tools at the same time.  Removing the module
parameters with the last patch might be rushed, they should probably
remain for a few kernel cycles with a warning.  When the tools are
updated for the new interface, they should probably maintain fallback
support for the module parameters for a while as well.

- Chris
