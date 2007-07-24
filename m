From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH]: revised make xfrm_audit_log more generic patch
Date: Tue, 24 Jul 2007 13:10:59 -0400
Message-ID: <200707241310.59640.sgrubb@redhat.com>
References: <200707232146.l6NLk50u001083@faith.austin.ibm.com>
	<200707241104.56310.sgrubb@redhat.com>
	<1185294806.15699.367.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <1185294806.15699.367.camel@faith.austin.ibm.com>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Tuesday 24 July 2007 12:33:26 pm Joy Latten wrote:
> > It also wouldn't hurt to change the text being sent to this function to
> > have a hyphen instead of a space, so "SPD delete" becomes "SPD-delete".
> > This keeps the parser happy.
>
> Steve, more for my education, should all entries have this sort of
> syntax, that is, a hyphen in it?

Only if its something that is important to have associated in reports. More 
that 1 or 2 hyphens is probably not good.

> I imagine some entries might be a bit more wordy and so I was wondering
> ahead of time how to do it.

The audit logs should be short as possible but contain everything necessary. 
You can have language in the record that makes it more understandable for 
people reading the raw record, but it won't necessarily be picked up by 
report parsers for searching or presentation.

If you want me to help review the choices, let me know offline and we can work 
through it.

-Steve
