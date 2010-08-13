From: kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Subject: [PATCH v3 0/3] cxgbi iscsi driver
Date: Fri, 13 Aug 2010 14:04:06 -0700
Message-ID: <201008132104.o7DL467w004119@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCNvLk8fsDxDU5pbjBBoEIWJp0w-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

[PATCH v3 0/3] cxgbi iscsi driver

From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

This patchset includes:

1. added libcxgbi as the common library for both cxgb4i and cxgb3i driver
2. added cxgb4i iscsi initiator v5.
3. changed cxgb3i to use libcxgbi.

Version 3 changes:
- re-worked defines of xxx_log_error/warn/info/debug to get rid of double
  indirection. 

Version 2 changes:
- Made dbg_level static to avoid compiling errors when both cxgb3i and cxgb4i
  are built into the kernel.
- Deleted cxgbi_fill_iscsi_transport() and cxgbi_fill_scsi_host_template().
  The iscsi_transport and scsi_host_template are initialized in the drivers
  instead of being filled in by the library at runtime..
- Only register with iscsi class transport once per driver type. 

Thanks.
Karen

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
