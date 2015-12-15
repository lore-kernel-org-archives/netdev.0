From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Tue, 15 Dec 2015 12:32:44 +0100
Message-ID: <1450179164.17387.18.camel@suse.com>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
	 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
	 <20151208143305.GB18728@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Lu Baolu <baolu.lu@linux.intel.com>
To: Peter Wu <peter@lekensteyn.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151208143305.GB18728@al>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-08 at 15:33 +0100, Peter Wu wrote:
> Can you have a look? I guess that reset_resume needs different
> treatment, but don't know how to do it properly as suspend is not
> called
> before system reset (because the device is apparently already in
> suspended state).
> 
> I think that this new issue can be addressed in a different patch,
> this
> patch solves a more severe lockup. Opinions?

We do not know in advance whether resume() or reset_resume()
will be called after S3. A driver must be ready for both.


	Regards
		Oliver
