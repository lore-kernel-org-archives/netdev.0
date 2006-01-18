From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 5/5] [RFC] Infiniband: connection
	abstraction
Date: Wed, 18 Jan 2006 07:43:09 -0800
Message-ID: <adavewhwnhu.fsf@cisco.com>
References: <ORSMSX401yEXUIEAOeI00000043@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX401yEXUIEAOeI00000043@orsmsx401.amr.corp.intel.com> (Sean
	Hefty's message of "Tue, 17 Jan 2006 15:44:48 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

 > +struct ucma_file {
 > +	struct semaphore	mutex;

This should be a struct mutex instead, I think.

 > +static DECLARE_MUTEX(ctx_mutex);

Same here.

 - R.
